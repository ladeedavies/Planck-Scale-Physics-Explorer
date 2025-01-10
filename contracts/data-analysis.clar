;; Data Analysis Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))

;; Data Variables
(define-data-var analysis-counter uint u0)
(define-map data-analyses uint {
    setup-id: uint,
    analyst: principal,
    results: (string-utf8 1000),
    timestamp: uint,
    status: (string-ascii 10)
})

;; Public Functions
(define-public (submit-analysis (setup-id uint) (results (string-utf8 1000)))
    (let ((analysis-id (+ (var-get analysis-counter) u1)))
        (map-set data-analyses analysis-id {
            setup-id: setup-id,
            analyst: tx-sender,
            results: results,
            timestamp: block-height,
            status: "pending"
        })
        (var-set analysis-counter analysis-id)
        (ok analysis-id)
    )
)

(define-public (update-analysis-status (analysis-id uint) (new-status (string-ascii 10)))
    (let ((analysis (unwrap! (map-get? data-analyses analysis-id) err-invalid-parameters)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (or (is-eq new-status "approved") (is-eq new-status "rejected")) err-invalid-parameters)
        (map-set data-analyses analysis-id (merge analysis {
            status: new-status
        }))
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-analysis (analysis-id uint))
    (map-get? data-analyses analysis-id)
)

(define-read-only (get-analysis-count)
    (var-get analysis-counter)
)

