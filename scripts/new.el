#!/usr/bin/env emacs --script

(let* ((slug (car command-line-args-left))
       (now (current-time))
       (year (format-time-string "%Y" now))
       (month (format-time-string "%m" now))
       (date-str (format-time-string "<%Y-%m-%d %a>" now))
       (filename (format "%s-%s.org" (format-time-string "%Y%m%d" now) slug))
       (dir (format "%s/%s" year month))
       (path (format "%s/%s" dir filename)))
  (unless slug
    (message "Usage: new.el <slug>")
    (kill-emacs 1))
  (make-directory dir t)
  (with-temp-buffer
    (insert (format "* %s\n" slug))
    (insert (format "%s\n" date-str))
    (insert "\nWrite...\n")
    (insert "\n-----\n\n")
    (insert "[[file:../../index.org][index]] :: [[file:../../about.org][about]]\n")
    (write-file path))
  (message "Created %s" path))
