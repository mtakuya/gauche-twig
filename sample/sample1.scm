(use twig)
(define user USER)
(define pass PASS)
(define twitter-client (twig:make-client user pass))
(display ((twitter-client :tweet!) "twig"))
