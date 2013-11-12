(define (botcmd-handle msg irc-send)
	(define msg-chunked (string-split msg " "))
	(cond
		((string=? (car (cdr (cdr (cdr msg-chunked)))) ":(o3")
			(define cmd (car (string-split (car (cdr (cdr (cdr (cdr msg-chunked))))) ")")))
			(define chan (car (cdr (cdr msg-chunked))))
			(irc-send (string-append "PRIVMSG " chan " :cmd: '" cmd "'")))))
