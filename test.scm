(use gauche.test)
(test-start "twig (v0.0.2)")
(load "./test/test1")
(test-module 'twig)
(test-module 'rfc.http)
(test-module 'rfc.uri)
(test-module 'rfc.base64)
(test-end)