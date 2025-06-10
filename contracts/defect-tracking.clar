;; Defect Tracking Contract
;; Tracks manufacturing defects and their resolution

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u400))
(define-constant ERR_DEFECT_NOT_FOUND (err u401))
(define-constant ERR_INVALID_SEVERITY (err u402))
(define-constant ERR_INVALID_STATUS (err u403))

;; Severity levels
(define-constant SEVERITY_LOW u1)
(define-constant SEVERITY_MEDIUM u2)
(define-constant SEVERITY_HIGH u3)
(define-constant SEVERITY_CRITICAL u4)

;; Defect status
(define-constant STATUS_OPEN u0)
(define-constant STATUS_IN_PROGRESS u1)
(define-constant STATUS_RESOLVED u2)
(define-constant STATUS_CLOSED u3)

;; Data structures
(define-map defects
  { defect-id: uint }
  {
    manufacturer-id: principal,
    inspection-id: (optional uint),
    title: (string-ascii 100),
    description: (string-ascii 500),
    severity: uint,
    status: uint,
    reported-date: uint,
    resolved-date: (optional uint),
    reported-by: principal,
    assigned-to: (optional principal),
    resolution-notes: (optional (string-ascii 500))
  }
)

(define-map defect-categories
  { category: (string-ascii 50) }
  {
    defect-ids: (list 100 uint),
    total-count: uint
  }
)

(define-data-var next-defect-id uint u1)

;; Public functions
(define-public (report-defect
  (manufacturer-id principal)
  (inspection-id (optional uint))
  (title (string-ascii 100))
  (description (string-ascii 500))
  (severity uint)
  (category (string-ascii 50))
)
  (let ((defect-id (var-get next-defect-id)))
    (asserts! (<= severity SEVERITY_CRITICAL) ERR_INVALID_SEVERITY)
    (asserts! (>= severity SEVERITY_LOW) ERR_INVALID_SEVERITY)
    (map-set defects
      { defect-id: defect-id }
      {
        manufacturer-id: manufacturer-id,
        inspection-id: inspection-id,
        title: title,
        description: description,
        severity: severity,
        status: STATUS_OPEN,
        reported-date: block-height,
        resolved-date: none,
        reported-by: tx-sender,
        assigned-to: none,
        resolution-notes: none
      }
    )
    ;; Add to category
    (let ((current-category (default-to { defect-ids: (list), total-count: u0 }
                                       (map-get? defect-categories { category: category }))))
      (map-set defect-categories
        { category: category }
        {
          defect-ids: (unwrap-panic (as-max-len? (append (get defect-ids current-category) defect-id) u100)),
          total-count: (+ (get total-count current-category) u1)
        }
      )
    )
    (var-set next-defect-id (+ defect-id u1))
    (ok defect-id)
  )
)

(define-public (assign-defect (defect-id uint) (assigned-to principal))
  (let ((defect (unwrap! (map-get? defects { defect-id: defect-id }) ERR_DEFECT_NOT_FOUND)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set defects
      { defect-id: defect-id }
      (merge defect { assigned-to: (some assigned-to) })
    )
    (ok true)
  )
)

(define-public (update-defect-status (defect-id uint) (new-status uint))
  (let ((defect (unwrap! (map-get? defects { defect-id: defect-id }) ERR_DEFECT_NOT_FOUND)))
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER)
                  (is-eq tx-sender (get manufacturer-id defect))
                  (is-eq (some tx-sender) (get assigned-to defect))) ERR_UNAUTHORIZED)
    (asserts! (<= new-status STATUS_CLOSED) ERR_INVALID_STATUS)
    (map-set defects
      { defect-id: defect-id }
      (merge defect { status: new-status })
    )
    (ok true)
  )
)

(define-public (resolve-defect (defect-id uint) (resolution-notes (string-ascii 500)))
  (let ((defect (unwrap! (map-get? defects { defect-id: defect-id }) ERR_DEFECT_NOT_FOUND)))
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER)
                  (is-eq tx-sender (get manufacturer-id defect))
                  (is-eq (some tx-sender) (get assigned-to defect))) ERR_UNAUTHORIZED)
    (map-set defects
      { defect-id: defect-id }
      (merge defect {
        status: STATUS_RESOLVED,
        resolved-date: (some block-height),
        resolution-notes: (some resolution-notes)
      })
    )
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-defect (defect-id uint))
  (map-get? defects { defect-id: defect-id })
)

(define-read-only (get-category-defects (category (string-ascii 50)))
  (map-get? defect-categories { category: category })
)

(define-read-only (get-next-defect-id)
  (var-get next-defect-id)
)
