;; Planck Scale NFT Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; NFT Definition
(define-non-fungible-token planck-scale-discovery uint)

;; Data Variables
(define-data-var last-token-id uint u0)
(define-map token-metadata uint {
    name: (string-ascii 100),
    description: (string-utf8 1000),
    discoverer: principal,
    discovery-date: uint,
    related-model: uint
})

;; Public Functions
(define-public (mint (name (string-ascii 100)) (description (string-utf8 1000)) (related-model uint))
    (let ((token-id (+ (var-get last-token-id) u1)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (nft-mint? planck-scale-discovery token-id tx-sender))
        (map-set token-metadata token-id {
            name: name,
            description: description,
            discoverer: tx-sender,
            discovery-date: block-height,
            related-model: related-model
        })
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-public (transfer (token-id uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? planck-scale-discovery token-id) err-not-token-owner)) err-not-token-owner)
        (try! (nft-transfer? planck-scale-discovery token-id tx-sender recipient))
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-token-metadata (token-id uint))
    (map-get? token-metadata token-id)
)

(define-read-only (get-last-token-id)
    (var-get last-token-id)
)

