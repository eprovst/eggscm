(module (eggscm iteration)
        (repeat
         for)

        (import scheme
                (chicken base))

        (define-syntax for
          (syntax-rules (from to do)
            ((_ i from a to b do body ...)
             (do ((i a (+ i 1)))
                 ((= i b) '())
                body ...))))

        (define-syntax repeat
          (syntax-rules ()
            ((_ n body ...)
             (letrec ((aux (lambda (i f)
                             (when (> i 0)
                               (f) (aux (- i 1) f)))))
               (aux n (lambda () body ...)))))))
