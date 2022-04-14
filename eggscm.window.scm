(module (eggscm window)
        (initialize-window-and-canvas
         window-title
         screenshot
         flush-canvas
         width
         height
         size
         resizable
         background
         canvas-set)

        (import scheme
          (chicken base)
          (chicken condition)
          (prefix sdl2 "sdl:"))

        (define the-window '())

        (define the-canvas '())

        (define (initialize-window-and-canvas)
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
          (set! the-canvas (sdl:create-renderer! the-window)))

        (define (window-title title)
          (sdl:window-title-set! the-window title))

        (define (size width height)
          (sdl:window-size-set! the-window (list width height)))

        (define (resizable bool)
          (sdl:window-resizable-set! the-window bool))
        
        (define (screenshot file)
          (flush-canvas)
          (sdl:save-bmp! (sdl:window-surface the-window) file))

        (define (flush-canvas)
          (sdl:render-present! the-canvas))

        (define (width)
          (let-values (((width _) (sdl:window-size the-window)))
            width))

        (define (height)
          (let-values (((_ height) (sdl:window-size the-window)))
            height))

        (define (canvas-in-bounds? x y)
          (and (>= x 0) (< x (width))
               (>= y 0) (< y (height))))

        (define (background color)
          (sdl:render-draw-color-set! the-canvas color)
          (sdl:render-clear! the-canvas))

        (define (canvas-set x y color)
          (when (canvas-in-bounds? x y)
            (sdl:render-draw-color-set! the-canvas color)
            (sdl:render-draw-point! the-canvas x y))))
