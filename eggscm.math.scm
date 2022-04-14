(module (eggscm math)
        (f->i
         clamp
         mod
         linear-map)

        (import scheme)

        (define (f->i f)
          (inexact->exact (round f)))

        (define (clamp f a b)
          (max a (min f b)))

        (define (mod f a)
          (let ((m (- f (* (truncate (/ f a)) a))))
            (if (> m 0) m (+ m a))))

        ; map f from range a b to c d linearly
        (define (linear-map f a b c d)
          (+ c (* (/ (- (* 1.0 f) a) (- b a))
                  (- d c)))))
