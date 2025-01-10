;; Experimental Setup Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))

;; Data Variables
(define-data-var setup-counter uint u0)
(define-map experimental-setups uint {
    name: (string-ascii 50),
    description: (string-utf8 500),
    creator: principal,
    parameters: (list 10 (tuple (name (string-ascii 20)) (value uint))),
    status: (string-ascii 10)
})

;; Public Functions
(define-public (create-setup (name (string-ascii 50)) (description (string-utf8 500)) (parameters (list 10 (tuple (name (string-ascii 20)) (value uint)))))
    (let ((setup-id (+ (var-get setup-counter) u1)))
        (map-set experimental-setups setup-id {
            name: name,
            description: description,
            creator: tx-sender,
            parameters: parameters,
            status: "active"
        })
        (var-set setup-counter setup-id)
        (ok setup-id)
    )
)

(define-public (update-setup-status (setup-id uint) (new-status (string-ascii 10)))
    (let ((setup (unwrap! (map-get? experimental-setups setup-id) err-invalid-parameters)))
        (asserts! (is-eq (get creator setup) tx-sender) err-owner-only)
        (asserts! (or (is-eq new-status "active") (is-eq new-status "completed") (is-eq new-status "failed")) err-invalid-parameters)
        (map-set experimental-setups setup-id (merge setup {
            status: new-status
        }))
        (ok true)
    )
)

(define-public (update-setup-parameters (setup-id uint) (new-parameters (list 10 (tuple (name (string-ascii 20)) (value uint)))))
    (let ((setup (unwrap! (map-get? experimental-setups setup-id) err-invalid-parameters)))
        (asserts! (is-eq (get creator setup) tx-sender) err-owner-only)
        (map-set experimental-setups setup-id (merge setup {
            parameters: new-parameters
        }))
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-setup (setup-id uint))
    (map-get? experimental-setups setup-id)
)

(define-read-only (get-setup-count)
    (var-get setup-counter)
)

