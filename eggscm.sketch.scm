(module (eggscm sketch)
        (frame
         frame-rate
         frame-rate!
         loop?
         loop!
         sketch)

        (import scheme
          (chicken base)
          (eggscm iteration)
          (eggscm window)
          (eggscm math)
          (prefix sdl2 "sdl:"))

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

        (define (sketch setup-code draw-code)
          (initialize-window!)
          (set! the-frame 0)
          (setup-code)
          (canvas-flush!)
          (while (not (sdl:quit-requested?))
            ; TODO: do we need to flush events after frame?
            (if (or (loop?) (= the-frame 0))
              (begin (set! the-frame (+ the-frame 1))
                     (run-in-one-frame draw-code)
                     (canvas-flush!))
              (sdl:wait-event!)))
          (sdl:quit!)))
