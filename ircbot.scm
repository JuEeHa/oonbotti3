#lang scheme
(include "botcmd.scm")

(define server "irc.freenode.net")
(define port   6667)
(define nick   "oonbotti3")
(define chan   '("#osdev-offtopic"))

(define (connhandler)
	(define connthread (thread-receive))
	(define-values (in out) (tcp-connect server port))
	(define (irc-send s)
		(display (string-append s "\r\n") out)
		(display (string-append s "\n")))
	
	(file-stream-buffer-mode out 'none)
	(file-stream-buffer-mode in 'none)
	
	(irc-send (string-append "NICK " nick))
	(irc-send (string-append "USER " nick " a a :" nick))
	(map (lambda (x) (irc-send (string-append "JOIN " x))) chan)
	
	(define (irc-recv)
		(define msg (read-line in))
		(thread-send connthread (cons 'inmsg msg) #f)
		(irc-recv))
	(define (loop)
		(define threadmsg (thread-receive))
		(cond
			((eq? (car threadmsg) 'inmsg)
				(define msg (cdr threadmsg))
				(cond
					((string=? (car (string-split msg " ")) "PING")
						(display "PONG :hjdicks\r\n" out))
					((string=? (car (cdr (string-split msg " "))) "PRIVMSG")
						(display msg)
						(display "\n")
						(botcmd-handle msg irc-send))
					(else
						(display msg)
						(display "\n"))))
			((eq? (car threadmsg) 'outmsg)
				(irc-send (cdr threadmsg)))
			((eq? (car threadmsg) 'quit)
				(kill-thread irc-recv-thread)))
		(loop))
	(define irc-recv-thread (thread irc-recv))
	(loop)
	(close-output-port out)
	(close-input-port in))

(define connthread (thread connhandler))
(thread-send connthread connthread #f)
(define (keyhandler)
	(define inp (read-line))
	(cond
		((string=? (car (string-split inp " ")) "/q")
			(thread-send connthread '(quit)))
		(else
			(thread-send connthread (cons 'outmsg inp))
			(keyhandler))))
(keyhandler)
