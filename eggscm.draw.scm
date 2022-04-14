(module (eggscm draw)
        (color
         pixel)

        (import scheme
                (chicken base)
                (eggscm window)
                (eggscm color)
                (eggscm vectors))

        (define the-color (rgb 1 1 1))

        (define (color color)
          (set! the-color color))

        (define (pixel p)
          (let-values (((x y) (point->pixels p)))
            (canvas-set x y the-color))))
