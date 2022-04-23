(import eggscm)

(define (setup)
  (size! 500 300)
  (window-title! "Julia set")
  (resizable! #t))

(define fragment-shader
  "#version 330 core

   uniform vec2 u_resolution;

   void main() {
       vec2 p = 2.0*gl_FragCoord.xy / u_resolution - 1.0;
       p *= vec2(1.6, 1.1);

       int i;
       for(i = 0; i <= 500; i++) {
           p = vec2(p.x*p.x - p.y*p.y,
                    2*p.x*p.y) + vec2(-0.744, 0.148);
           if (dot(p,p) > 4.0) break;
       }

       gl_FragColor = vec4(vec3(1-i/500.0), 1.0);
   }")

(shader setup fragment-shader)

