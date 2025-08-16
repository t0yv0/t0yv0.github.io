#!/usr/bin/env emacs --script

(defun read-first-two-lines (file)
  "Read the first two lines from FILE and return them as a list."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (list (buffer-substring-no-properties
           (line-beginning-position)
           (line-end-position))
          (progn (forward-line 1)
                 (buffer-substring-no-properties
                  (line-beginning-position)
                  (line-end-position))))))


(defun chop-prefix (prefix s)
  "Remove PREFIX from the beginning of S if it exists, otherwise return S unchanged."
  (if (and (>= (length s) (length prefix))
           (string-equal (substring s 0 (length prefix)) prefix))
      (substring s (length prefix))
    s))


(defun process-entry (file)
  (let* ((entry (read-first-two-lines file))
         (title (chop-prefix "* " (seq-elt entry 0)))
         (dt (seq-elt entry 1)))

    (insert (format "- [[file:%s][%s]] %s\n" file title dt))))


(with-temp-buffer
  (insert "* Anton's Weblog\n\n")
  (seq-each #'process-entry
            (seq-sort #'string>
                      (file-expand-wildcards "2***/*/*.org")))

  (insert "\n-----\n")
  (insert "[[file:about.org][about]]\n")

  (write-file "index.org")
  (message "rebuilt index.org"))


(setq org-publish-project-alist
      '(("org"
         :org-src-fontify-natively t
         :base-directory "~/code/t0yv0.github.io/"
         :base-extension "org"
         :recursive t
         :publishing-function org-html-publish-to-html
         :publishing-directory "~/code/t0yv0.github.io/"
         :html-postamble nil
         :section-numbers nil
         :with-toc nil
         :html-head "<link rel=\"stylesheet\" href=\"/css/skeleton.min.css\" type=\"text/css\"/>")))


(org-publish "org")
