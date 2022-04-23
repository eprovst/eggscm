(module (eggscm sketch)
        (frame
         frame-rate
         frame-rate!
         loop?
         loop!
         sketch
         shader)

        (import scheme
          (chicken base)
          (chicken bitwise)
          (chicken random)
          (eggscm iteration)
          (eggscm window)
          (eggscm math)
          (prefix sdl2 "sdl:")
          (prefix epoxy "gl:")
          (prefix gl-utils "gl-utils:"))

        (define the-frame 0)

        (define (frame)
          the-frame)

        (define the-frame-rate 60)

        (define (frame-rate)
          the-frame-rate)

        (define (frame-rate! fps)
          (set! the-frame-rate fps))

        (define the-loop #t)

        (define (loop?)
          the-loop)

        (define (loop! b)
          (assert (boolean? b))
          (set! the-loop b))

        (define (run-in-one-frame frame-code)
          (let ((start-time (sdl:get-ticks)))
            (frame-code)
            ; Correct for frame rate, if set
            (when (> the-frame-rate 0)
              (let ((frame-time (- (sdl:get-ticks) start-time))
                    (goal-time (integer (/ 1000. the-frame-rate))))
                (when (< frame-time goal-time)
                  (sdl:delay! (- goal-time frame-time)))))))

        ; Sketch
        (define (sketch setup-code draw-code)
          (initialize-window!)
          (set! the-frame 0)
          (setup-code)
          (canvas-flush!)
          (while (not (sdl:quit-requested?))
            (if (or (loop?) (= the-frame 0))
              (begin (set! the-frame (+ the-frame 1))
                     (run-in-one-frame draw-code)
                     (canvas-flush!))
              (sdl:wait-event!)))
          (sdl:quit!))

        ; Shader
        (define fill-window-vertex-shader
          "#version 330 core

          const vec2 verts[4] = vec2[] (
              vec2(-1.0,  1.0),
              vec2(-1.0, -1.0),
              vec2( 1.0,  1.0),
              vec2( 1.0, -1.0)
          );

          void main() {
              gl_Position = vec4(verts[gl_VertexID], 0.0, 1.0);
          }")

        (define the-program '())

        (define (initialize-fragment-shader! fragment-shader)
          ; set shader
          (set! the-program
            (gl-utils:make-program
              (list (gl-utils:make-shader gl:+vertex-shader+
                                          fill-window-vertex-shader)
                    (gl-utils:make-shader gl:+fragment-shader+
                                          fragment-shader))))
          (let ((e (gl:get-error)))
            (when (not (= e gl:+no-error+))
              ; Compilation error printed, now exit
              (exit)))
          (gl:use-program the-program)
          ; empty VAO, as we don't have any vertex data
          (let ((vao (gl-utils:gen-vertex-array)))
            (gl:bind-vertex-array vao)))

        (define (render-fragment-shader)
          ; Set uniforms
          (let ((u-time (gl:get-uniform-location the-program "u_time"))
                (u-resolution (gl:get-uniform-location the-program "u_resolution"))
                (u-frame (gl:get-uniform-location the-program "u_frame"))
                (u-seed (gl:get-uniform-location the-program "u_seed")))
            (gl:uniform1f u-time (/ (sdl:get-ticks) 1000.0))
            (let ((w (width))
                  (h (height)))
              (gl:viewport 0 0 w h)
              (gl:uniform2f u-resolution w h))
            (gl:uniform1f u-frame the-frame)
            (gl:uniform1f u-seed (pseudo-random-real)))
          (gl:clear (bitwise-ior gl:+color-buffer-bit+
                                 gl:+depth-buffer-bit+))
          ; draw rectangle across screen using vertex shader
          ; which will activate the fragment shader across
          ; the screen
          (gl:draw-arrays gl:+triangle-strip+ 0 4)
          (gl-utils:check-error))

        (define (shader setup-code fragment-shader
                        #!optional after-frame-code)
          (initialize-opengl-window!)
          (set! the-frame 0)
          (setup-code)
          (initialize-fragment-shader! fragment-shader)
          (while (not (sdl:quit-requested?))
            (if (or (loop?) (= the-frame 0))
                (begin (set! the-frame (+ the-frame 1))
                       (run-in-one-frame
                         (lambda ()
                           (render-fragment-shader)
                           (if after-frame-code
                               (begin (opengl-to-canvas!)
                                      (after-frame-code)
                                      (canvas-flush!))
                               (opengl-flush!)))))
                (sdl:wait-event!)))
          (sdl:quit!)))
