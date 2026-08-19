;;; ~/.config/doom/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Mohit Kumar")
(setq user-mail-address "codingbymohit@gmail.com")

(setq doom-theme 'doom-gruvbox)

(after! org
  (setq org-directory "~/org"))

(after! org-roam
  (setq org-roam-directory (file-truename "~/org"))

  (setq org-roam-capture-templates
        '(("n" "Note" plain "%?"
           :target (file+head "notes/${slug}.org"
                              "#+title: ${title}\n#+created: %U\n\n")
           :unnarrowed t)

          ("p" "Project" plain "%?"
           :target (file+head "projects/${slug}.org"
                              "#+title: ${title}\n#+created: %U\n\n")
           :unnarrowed t)

          ("b" "Book" plain "%?"
           :target (file+head "books/${slug}.org"
                              "#+title: ${title}\n#+created: %U\n\n")
           :unnarrowed t)

          ("j" "Journal" plain "%?"
           :target (file+head "journal/${slug}.org"
                              "#+title: ${title}\n#+created: %U\n\n")
           :unnarrowed t))))

