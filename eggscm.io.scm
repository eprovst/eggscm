(module (eggscm io) *

        (import scheme
                (chicken io))

        (define (read-file file-name)
          (call-with-input-file file-name
            (lambda (port) (read-string #f port)))))
