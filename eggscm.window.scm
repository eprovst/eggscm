(module (eggscm window)
        (initialize-window
         window-title
         screenshot
         flush-canvas
         width
         height
         size
         resizable
         background
         canvas-get
         canvas-set)

        (import scheme
          (chicken base)
          (chicken condition)
          (prefix sdl2 "sdl:"))

        (define the-window '())

        (define (get-canvas)
          (sdl:window-surface the-window))

        (define (initialize-window)
          ; Initialise SDL
          (sdl:set-main-ready!)
          (sdl:init! '(video))

          ; Register clean up
          (on-exit sdl:quit!)
          (current-exception-handler
            (let ((original-handler (current-exception-handler)))
              (lambda (exception)
                (sdl:quit!)
                (original-handler exception))))

          ; Create a window
          (set! the-window (sdl:create-window! "eggscm"
                                               'undefined 'undefined
                                               600 400))
          (sdl:window-minimum-size-set! the-window '(16 16))
          (sdl:quit-requested?)) ; HACK: wait for full init

        (define (window-title title)
          (sdl:window-title-set! the-window title))

        (define (size width height)
          (sdl:window-size-set! the-window (list width height)))

        (define (resizable bool)
          (sdl:window-resizable-set! the-window bool))
        
        (define (screenshot file)
          (sdl:save-bmp! (get-canvas) file))

        (define (flush-canvas)
          (get-canvas) ; Make sure there is a canvas to flush
          (sdl:update-window-surface! the-window))

        (define (width)
          (sdl:surface-w (get-canvas)))

        (define (height)
          (sdl:surface-h (get-canvas)))

        (define (canvas-in-bounds? x y)
          (and (>= x 0) (< x (width))
               (>= y 0) (< y (height))))

        (define (background color)
          (sdl:fill-rect! (get-canvas) #f color))

        (define (canvas-get x y)
          (if (canvas-in-bounds? x y)
            (sdl:surface-ref (get-canvas) x y)
            (sdl:make-color 0 0 0 0)))

        (define (canvas-set x y color)
          (when (canvas-in-bounds? x y)
            (sdl:surface-set! (get-canvas) x y color))))
