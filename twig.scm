;;;
;;; twig.scm - Twitter client (v0.0.2)
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
  (use simple-rss)
  (export twig:make-client twig:get-user-tweet)
)
 
(select-module twig)
 
(define uri-host "twitter.com")
(define path-statuses/update "/statuses/update.xml")
(define path-statuses/user-timeline "/statuses/user_timeline/")
(define query-status "status")
 
(define (make-basic-auth-token user pass)
  (let1 user:pass
        (base64-encode-string (format "~a:~a" user pass))
        #`"Basic ,user:pass"))

(define (make-uri-update message)
  (let1 message
        (uri-encode-string message)
        (format "~a?~a=~a" path-statuses/update query-status message)))
 
(define (twig:make-client user pass)
  (define (twig:post message)
    (http-post
     uri-host
     (make-uri-update message)
     ""
     :authorization (make-basic-auth-token user pass)))
  (define (twig:tweet! message)
    (if (< 140 (string-length message))
        (error "over 140 characters:" message)
        (receive (s h b) (twig:post message)
              (if (string=? s "200")
                  s
                  (error "got:"s h b)))))
  (lambda (key)
    (if (eq? key :tweet!)
        (cut twig:tweet! <>)
        #f)))
 
(define (twig:get-user-tweet id path)
  (rss:uri->slist 
   #`"http://,uri-host,path-statuses/user-timeline,|id|.rss"
   path))
        
(provide "twig")
