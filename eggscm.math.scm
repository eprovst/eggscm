(module (eggscm math)
        (integer
         pi
         pi/2
         tau
         radians
         degrees
         sind
         cosd
         tand
         clamp
         mod
         linear-map)

        (import scheme)

        (define (integer f)
          (inexact->exact (round f)))

        (define pi   (* 4 (atan 1)))
        (define pi/2 (* 2 (atan 1)))
        (define tau  (* 8 (atan 1)))

        (define (radians d)
          (/ (* d pi) 180))

        (define (degrees r)
          (/ (* r 180) pi))

        (define (sind d)
          (sin (radians d)))

        (define (cosd d)
          (cos (radians d)))

        (define (tand d)
          (tan (radians d)))

        (define (clamp f a b)
          (max a (min f b)))

        (define (mod f a)
          (let ((m (- f (* (truncate (/ f a)) a))))
            (if (> m 0) m (+ m a))))

        ; map f from range a b to c d linearly
        (define (linear-map f a b c d)
          (+ c (* (/ (- (* 1.0 f) a) (- b a))
                  (- d c)))))
