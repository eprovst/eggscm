(module (eggscm time)
        (millis
         time-it)

        (import scheme
          (prefix sdl2 "sdl:"))

        (define (millis)
          (sdl:get-ticks))

        (define-syntax time-it
          (syntax-rules ()
            ((_ body ...)
             (let ((start-time (millis))
                   (result (begin body ...)))
               (print (/ (- (millis) start-time) 1000.0) " seconds")
               result)))))
