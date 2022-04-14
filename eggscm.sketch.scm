(module (eggscm sketch)
        (sketch
         frame-rate)

        (import scheme
          (chicken base)
          (eggscm window)
          (eggscm math)
          (prefix sdl2 "sdl:"))

        (define the-frame-rate 60)

        (define (frame-rate fps)
          (set! the-frame-rate fps))

        (define (execute-in-frame frame-code)
          (let ((start-time (sdl:get-ticks)))
            (frame-code)
            ; Correct for frame rate, if set
            (when (> the-frame-rate 0)
              (let ((frame-time (- (sdl:get-ticks) start-time))
                    (goal-time (f->i (/ 1000. the-frame-rate))))
                (when (< frame-time goal-time)
                  (sdl:delay! (- goal-time frame-time)))))))

        (define (sketch setup-code loop-code)
          (initialize-window-and-canvas)
          (setup-code)
          (flush-canvas)
          (run-loop loop-code))

        (define (run-loop loop-code)
          (when (sdl:quit-requested?)
            (exit))

          (execute-in-frame loop-code)

          ; TODO: do we need to flush events?
          (flush-canvas)
          (run-loop loop-code)))
