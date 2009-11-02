;;; twig.scm - Twitter client (v0.0.1)
;;;
;;; Copyright (c) 2009 Takuya Mannami <mtakuya@users.sourceforge.jp>
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions
;;; are met:
;;;
;;; 1. Redistributions of source code must retain the above copyright
;;; notice, this list of conditions and the following disclaimer.
;;;
;;; 2. Redistributions in binary form must reproduce the above copyright
;;; notice, this list of conditions and the following disclaimer in the
;;; documentation and/or other materials provided with the distribution.
;;;
;;; 3. Neither the name of the authors nor the names of its contributors
;;; may be used to endorse or promote products derived from this
;;; software without specific prior written permission.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;; OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
;;; TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;;; PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;;; LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;; 

(define-module twig
  (use rfc.http)
  (use rfc.uri)
  (use rfc.base64)
  (export twig:make-client)
)

(select-module twig)

(define server "twitter.com")
(define uri-update "/statuses/update.xml?")
(define uri-status "status=")
;(define uri-source "source=")
;(define client-name "twig")
(define basic "Basic ")


(define (request-uri str) (string-append uri-update str))
;  (string-append uri-update str "&" uri-source
;                 (uri-encode-string client-name)))

(define (user&pass->base64str user pass)
  (string-append basic
                 (base64-encode-string (string-append user ":" pass)))) ;:encoding

(define (twig:make-client user pass)
  (define (twig:post status)
    (http-post
     server
     (request-uri status)
     ""
     :authorization (user&pass->base64str user pass)))

  ;Update user status
  (define (twig:update str)
    (if (< 140 (string-length str))
        "Error : string length > 140"
        (let1 status 
            (string-append uri-status (uri-encode-string str))
            (twig:post status))))
  ;Dispatch. only one method (v0.0.1).
  (lambda (key)
    (if (eq? key :update)
        (cut twig:update <>)
        #f)))

(provide "twig")

