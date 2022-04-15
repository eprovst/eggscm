(module (eggscm draw)
        (color
         color!
         background!
         pixel
         pixel!)

        (import scheme
                (chicken base)
                (eggscm window)
                (eggscm color)
                (eggscm vectors))

        (define the-color (rgb 1 1 1))

        (define (color)
          the-color)

        (define (color! color)
          (set! the-color color))

        (define (background! color)
          (canvas-fill! color))

        (define (pixel p)
          (let-values (((x y) (point->pixels p)))
            (canvas-pixel x y)))

        (define (pixel! p)
          (let-values (((x y) (point->pixels p)))
            (canvas-pixel! x y the-color))))
