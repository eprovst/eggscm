(module (eggscm draw)
        (mouse
         background!
         pixel
         pixel!
         color
         color!
         push-style!
         pop-style!
         origin!
         y-up?
         y-up!
         rotate!
         scale!
         shear-x!
         shear-y!
         translate!
         reset-transform!
         push-transform!
         pop-transform!
         push!
         pop!)

        (import scheme
                (chicken base)
                (eggscm color)
                (eggscm math)
                (eggscm vectors)
                (eggscm window))

        ;; Info
        (define (mouse)
          (let-values (((x y) (window-mouse-position)))
            (pixel->point x y)))

        ;; Drawing functions
        (define (background! color)
          (canvas-fill! color))

        (define (pixel p)
          (let-values (((x y) (point->pixel p)))
            (canvas-pixel x y)))

        (define (pixel! p)
          (let-values (((x y) (point->pixel p)))
            (canvas-pixel! x y (color))))

        ;; Style settings
        (define the-style
         (vector (rgb 1 1 1)))

        (define (color)
          (vector-ref the-style 0))

        (define (color! color)
          (vector-set! the-style 0 color))

        ;; Style stack
        (define the-style-stack '())

        (define (push-style!)
          (set! the-style-stack
                (cons the-style
                      the-style-stack)))

        (define (pop-style!)
          (when (not (null? the-style-stack))
            (set! the-style
              (car the-style-stack))
            (set! the-style-stack
              (cdr the-style-stack))))

        ;; Coordinate system settings
        (define the-origin (vt 0 0))

        (define (origin-vector)
          (if (equal? the-origin 'center)
              (vt (/ (width) 2) (/ (height) 2))
              the-origin))

        (define (origin! x #!optional y)
          (assert (or (and (equal? x 'center) (not y))
                      (and (pt? x) (not y))
                      (and (number? x) (number? y))))
          (cond ((equal? x 'center)
                 (set! the-origin 'center))
                ((pt? x)
                 (let-values (((x y) (crds (from-screen-space x))))
                   (set! the-origin (vt x y))))
                (else
                 (set! the-origin (vt x y)))))

        (define the-y-up #t)

        (define (y-up?)
          the-y-up)

        (define (y-up! b)
          (assert (boolean? b))
          (when (and (not (equal? the-y-up b))
                     (pt? the-origin))
            (set! the-origin (flip-y the-origin)))
          (set! the-y-up b))

        ;; Transform
        (define the-transform (mat-id))
        (define the-inverse-transform (mat-id))

        (define (translate! xo #!optional yo)
          (if yo
              (begin
                (assert (number? xo))
                (assert (number? yo))
                (set! the-transform
                      (mat*mat
                        (mat 1 0 xo
                             0 1 yo
                             0 0  1)
                        the-transform))
                (set! the-inverse-transform
                      (mat*mat
                        the-inverse-transform
                        (mat 1 0 (- xo)
                             0 1 (- yo)
                             0 0      1))))
              (let-values (((xo yo) (crds xo)))
                (translate! xo yo))))

        (define (scale! xs #!optional ys)
          (if ys
              (begin
                (assert (number? xs))
                (assert (number? ys))
                (set! the-transform
                      (mat*mat
                        (mat xs  0 0
                              0 ys 0
                              0  0 1)
                        the-transform))
                (set! the-inverse-transform
                      (mat*mat
                        the-inverse-transform
                        (mat (/ xs)      0 0
                                  0 (/ ys) 0
                                  0      0 1))))
              (scale! xs xs)))

        (define (rotate! angle)
          (assert (number? angle))
          (let ((s (sin angle))
                (c (cos angle)))
            (set! the-transform
                  (mat*mat
                    (mat c (- s) 0
                         s     c 0
                         0     0 1)
                    the-transform))
            (set! the-inverse-transform
                  (mat*mat
                    the-inverse-transform
                    (mat     c s 0
                         (- s) c 0
                             0 0 1)))))

        (define (shear-x! angle)
          (assert (number? angle))
          (set! the-transform
                (mat*mat
                  (mat 1 (- (tan angle)) 0
                       0               1 0
                       0               0 1)
                  the-transform))
          (set! the-inverse-transform
                (mat*mat
                  the-inverse-transform
                  (mat 1 (tan angle) 0
                       0           1 0
                       0           0 1))))

        (define (shear-y! angle)
          (assert (number? angle))
          (set! the-transform
                (mat*mat
                  (mat           1 0 0
                       (tan angle) 1 0
                                 0 0 1)
                  the-transform))
          (set! the-inverse-transform
                (mat*mat
                  the-inverse-transform
                  (mat               1 0 0
                       (- (tan angle)) 1 0
                                     0 0 1))))

        (define (reset-transform!)
          (set! the-transform (mat-id))
          (set! the-inverse-transform (mat-id)))

        ;; Transform stack
        (define the-transform-stack '())
        (define the-inverse-transform-stack '())

        (define (push-transform!)
          (set! the-transform-stack
                (cons the-transform
                      the-transform-stack))
          (set! the-inverse-transform-stack
                (cons the-inverse-transform
                      the-inverse-transform-stack)))

        (define (pop-transform!)
          (when (not (null? the-transform-stack))
            (set! the-transform
              (car the-transform-stack))
            (set! the-transform-stack
              (cdr the-transform-stack))
            (set! the-inverse-transform
              (car the-inverse-transform-stack))
            (set! the-inverse-transform-stack
              (cdr the-inverse-transform-stack))))

        ;; Control both transform and style stacks
        (define (push!)
          (push-style!)
          (push-transform!))

        (define (pop!)
          (pop-style!)
          (pop-transform!))

        ;; Coordinate transform
        (define (flip-y p)
          (assert (pt? p))
          (vec (vec-idx p 0)
               (- (height) (vec-idx p 1))
               (vec-idx p 2)))

        (define (to-screen-space p)
          (assert (pt? p))
          (let* ((Tp  (mat*vec the-transform p))
                 (sTp (add Tp (origin-vector))))
            (if (y-up?) (flip-y sTp) sTp)))

        (define (from-screen-space s)
          (assert (pt? s))
          (let* ((sTp (if (y-up?) (flip-y s) s))
                 (Tp  (sub sTp (origin-vector))))
            (mat*vec the-inverse-transform Tp)))

        (define (point->pixel p)
          (let-values (((x y) (crds (to-screen-space p))))
            (values (integer x) (integer y))))

        (define (pixel->point x y)
          (from-screen-space (pt x y))))
