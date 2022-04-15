(module (eggscm iteration)
        (for
         repeat
         while)

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
               (aux n (lambda () body ...))))))

        (define-syntax while
          (syntax-rules ()
            ((_ cond body ...)
             (letrec ((aux (lambda ()
                             (when cond
                               body ...
                               (aux)))))
                 (aux))))))
