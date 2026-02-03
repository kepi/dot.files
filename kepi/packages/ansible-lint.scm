(define-module (kepi packages ansible-lint)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system python)
  #:use-module (guix build-system pyproject))

(define-public python-ansible-lint
  (package
    (name "python-ansible-lint")
    (version "25.9.2")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "ansible_lint" version))
       (sha256
        (base32 "1956s5c4hvpl1dq9qbgn3bxh7fhlhzmvdjg72bpqncnx2xfqmshf"))))
    (build-system pyproject-build-system)
    (propagated-inputs (list python-ansible-compat
                             python-ansible-core
                             python-black
                             python-cffi
                             python-cryptography
                             python-distro
                             python-filelock
                             python-importlib-metadata
                             python-jsonschema
                             python-packaging
                             python-pathspec
                             python-pyyaml
                             python-referencing
                             python-ruamel-yaml
                             python-ruamel-yaml-clib
                             python-subprocess-tee
                             python-wcmatch
                             python-yamllint))
    (native-inputs (list python-setuptools python-setuptools-scm python-wheel))
    (home-page #f)
    (synopsis
     "Checks playbooks for practices and behavior that could potentially be improved")
    (description
     "Checks playbooks for practices and behavior that could potentially be improved.")
    (license #f)))
