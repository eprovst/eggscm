(module (eggscm sketch)
        (sketch
         frame
         frame-rate
         frame-rate!)

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

        (define (run-in-one-frame frame-code)
          (let ((start-time (sdl:get-ticks)))
            (frame-code)
            ; Correct for frame rate, if set
            (when (> the-frame-rate 0)
              (let ((frame-time (- (sdl:get-ticks) start-time))
                    (goal-time (integer (/ 1000. the-frame-rate))))
                (when (< frame-time goal-time)
                  (sdl:delay! (- goal-time frame-time)))))))

        (define (sketch setup-code loop-code)
          (initialize-window!)
          (set! the-frame 0)
          (setup-code)
          (while (not (sdl:quit-requested?))
            (canvas-flush!)
            (set! the-frame (+ the-frame 1))
            ; TODO: do we need to flush events after frame?
            (run-in-one-frame loop-code))
          (sdl:quit!)))
