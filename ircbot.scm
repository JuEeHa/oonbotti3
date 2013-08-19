#lang scheme

(define server "irc.freenode.net")
(define port   6667)
(define nick   "oonbotti3")
(define chan   '("#osdev-offtopic"))

(define (connhandler)
	(define-values (in out) (tcp-connect server port))
	(define (irc-send s)
		(display (string-append s "\r\n") out)
		(display (string-append s "\n")))
	
	(file-stream-buffer-mode out 'none)
	(file-stream-buffer-mode in 'none)
	
	(irc-send (string-append "NICK " nick))
	(irc-send (string-append "USER " nick " a a :" nick))
	(map (lambda (x) (irc-send (string-append "JOIN " x))) chan)
	
	(define (loop)
		(define msg (read-line in))
		(display msg)
		(display "\n")
		(cond
			((string=? (car (string-split msg " ")) "PING")
				(irc-send "PONG :hjdicks")))
		(loop))
	(loop)
	(close-output-port out)
	(close-input-port in))

(define connthread (thread connhandler))
(read-line)
