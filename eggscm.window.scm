(module (eggscm window)
        (initialize-window!
         initialize-opengl-window!
         opengl-flush!
         opengl-to-canvas!
         window-title
         window-title!
         window-mouse-position
         mouse-down?
         width
         height
         size
         size!
         resizable?
         resizable!
         screenshot!
         canvas-flush!
         canvas-fill!
         canvas-pixel
         canvas-pixel!)

        (import scheme
          (chicken base)
          (chicken condition)
          (prefix epoxy "gl:")
          (prefix sdl2 "sdl:"))

        (define the-window '())

        (define the-canvas '())

        (define opengl-mode? #f)

        (define (canvas)
          (if opengl-mode?
            (begin
              (when (or (null? the-canvas)
                        (not (= (sdl:surface-w the-canvas) (width)))
                        (not (= (sdl:surface-h the-canvas) (height))))
                (set! the-canvas (sdl:make-surface (width) (height) 'rgba8888)))
              the-canvas)
            (sdl:window-surface the-window)))

        (define (initialize-sdl!)
          ; Initialise SDL
          (sdl:set-main-ready!)
          (sdl:init! '(video))

          ; Register clean up
          (on-exit sdl:quit!)
          (current-exception-handler
            (let ((original-handler (current-exception-handler)))
              (lambda (exception)
                (sdl:quit!)
                (original-handler exception)))))

        (define (initialize-window!)
          (initialize-sdl!)

          ; Create a window
          (set! the-window (sdl:create-window! "eggscm"
                                               'undefined 'undefined
                                               600 400 '(shown)))
          (sdl:window-minimum-size-set! the-window '(16 16))
          (resizable! #f)
          (set! opengl-mode? #f)
          (sdl:quit-requested?)) ; HACK: wait for full init

        (define (initialize-opengl-window!)
          (initialize-sdl!)

          ; Create window
          (set! the-window (sdl:create-window! "eggscm"
                                               'undefined 'undefined
                                               600 400 '(opengl shown)))
          (sdl:window-minimum-size-set! the-window '(16 16))
          (resizable! #f)
          (set! opengl-mode? #t)

          ; Use OpenGL 3.3
          (sdl:gl-attribute-set! 'context-profile-mask 'core)
          (sdl:gl-attribute-set! 'context-major-version 3)
          (sdl:gl-attribute-set! 'context-minor-version 3)

          ; Create OpenGL context
          (sdl:gl-create-context! the-window)

          (sdl:quit-requested?)) ; HACK: wait for full init

        (define (opengl-flush!)
          (sdl:gl-swap-window! the-window))

        (define (opengl-to-canvas!)
          (gl:read-buffer gl:+back+)
          (gl:read-pixels 0 0 (width) (height)
                          gl:+rgba+ gl:+unsigned-int-8-8-8-8+
                          (sdl:surface-pixels-raw (canvas)))
          (gl:flush)  ; Start pipeline
          (gl:finish) ; Await end of pipeline
          (sdl:blit-surface! (sdl:flip-surface (canvas) #f #t) #f
                             (canvas) #f))

        (define (window-title)
          (sdl:window-title the-window))

        (define (window-title! title)
          (sdl:window-title-set! the-window title))

        (define (width)
          (let-values (((w _) (size))) w))

        (define (height)
          (let-values (((_ h) (size))) h))

        (define (size)
          (sdl:window-size the-window))

        (define (size! width height)
          (sdl:window-size-set! the-window (list width height)))

        (define (resizable?)
          (sdl:window-resizable? the-window))

        (define (resizable! bool)
          (sdl:window-resizable-set! the-window bool))

        (define (window-mouse-position)
          (let-values (((_ x y) (sdl:get-mouse-state)))
            (values x y)))

        (define (mouse-down?)
          (let-values (((btns _ _) (sdl:get-mouse-state)))
            (member 'left btns)))

        (define (screenshot! file)
          (sdl:save-bmp! (canvas) file))

        (define (canvas-flush!)
          (canvas) ; Make sure there is a canvas to flush
          (sdl:update-window-surface! the-window))

        (define (canvas-fill! color)
          (sdl:fill-rect! (canvas) #f color))

        (define (canvas-in-bounds? x y)
          (and (>= x 0) (< x (width))
               (>= y 0) (< y (height))))

        (define (canvas-pixel x y)
          (if (canvas-in-bounds? x y)
            (sdl:surface-ref (canvas) x y)
            (sdl:make-color 0 0 0 0)))

        (define (canvas-pixel! x y color)
          (when (canvas-in-bounds? x y)
            (sdl:surface-set! (canvas) x y color))))
