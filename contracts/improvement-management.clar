;; Improvement Management Contract
;; Manages quality improvements and tracks progress

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u500))
(define-constant ERR_IMPROVEMENT_NOT_FOUND (err u501))
(define-constant ERR_INVALID_STATUS (err u502))
(define-constant ERR_INVALID_PRIORITY (err u503))

;; Priority levels
(define-constant PRIORITY_LOW u1)
(define-constant PRIORITY_MEDIUM u2)
(define-constant PRIORITY_HIGH u3)
(define-constant PRIORITY_URGENT u4)

;; Improvement status
(define-constant STATUS_PROPOSED u0)
(define-constant STATUS_APPROVED u1)
(define-constant STATUS_IN_PROGRESS u2)
(define-constant STATUS_COMPLETED u3)
(define-constant STATUS_REJECTED u4)

;; Data structures
(define-map improvements
  { improvement-id: uint }
  {
    manufacturer-id: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    priority: uint,
    status: uint,
    proposed-date: uint,
    target-completion: uint,
    actual-completion: (optional uint),
    proposed-by: principal,
    approved-by: (optional principal),
    estimated-cost: uint,
    actual-cost: (optional uint),
    expected-impact: (string-ascii 200)
  }
)

(define-map improvement-metrics
  { improvement-id: uint }
  {
    baseline-score: uint,
    target-score: uint,
    actual-score: (optional uint),
    roi-percentage: (optional uint)
  }
)

(define-data-var next-improvement-id uint u1)

;; Public functions
(define-public (propose-improvement
  (manufacturer-id principal)
  (title (string-ascii 100))
  (description (string-ascii 500))
  (priority uint)
  (target-completion uint)
  (estimated-cost uint)
  (expected-impact (string-ascii 200))
  (baseline-score uint)
  (target-score uint)
)
  (let ((improvement-id (var-get next-improvement-id)))
    (asserts! (<= priority PRIORITY_URGENT) ERR_INVALID_PRIORITY)
    (asserts! (>= priority PRIORITY_LOW) ERR_INVALID_PRIORITY)
    (map-set improvements
      { improvement-id: improvement-id }
      {
        manufacturer-id: manufacturer-id,
        title: title,
        description: description,
        priority: priority,
        status: STATUS_PROPOSED,
        proposed-date: block-height,
        target-completion: target-completion,
        actual-completion: none,
        proposed-by: tx-sender,
        approved-by: none,
        estimated-cost: estimated-cost,
        actual-cost: none,
        expected-impact: expected-impact
      }
    )
    (map-set improvement-metrics
      { improvement-id: improvement-id }
      {
        baseline-score: baseline-score,
        target-score: target-score,
        actual-score: none,
        roi-percentage: none
      }
    )
    (var-set next-improvement-id (+ improvement-id u1))
    (ok improvement-id)
  )
)

(define-public (approve-improvement (improvement-id uint))
  (let ((improvement (unwrap! (map-get? improvements { improvement-id: improvement-id }) ERR_IMPROVEMENT_NOT_FOUND)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status improvement) STATUS_PROPOSED) ERR_INVALID_STATUS)
    (map-set improvements
      { improvement-id: improvement-id }
      (merge improvement {
        status: STATUS_APPROVED,
        approved-by: (some tx-sender)
      })
    )
    (ok true)
  )
)

(define-public (start-improvement (improvement-id uint))
  (let ((improvement (unwrap! (map-get? improvements { improvement-id: improvement-id }) ERR_IMPROVEMENT_NOT_FOUND)))
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) (is-eq tx-sender (get manufacturer-id improvement))) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status improvement) STATUS_APPROVED) ERR_INVALID_STATUS)
    (map-set improvements
      { improvement-id: improvement-id }
      (merge improvement { status: STATUS_IN_PROGRESS })
    )
    (ok true)
  )
)

(define-public (complete-improvement
  (improvement-id uint)
  (actual-cost uint)
  (actual-score uint)
)
  (let ((improvement (unwrap! (map-get? improvements { improvement-id: improvement-id }) ERR_IMPROVEMENT_NOT_FOUND))
        (metrics (unwrap! (map-get? improvement-metrics { improvement-id: improvement-id }) ERR_IMPROVEMENT_NOT_FOUND)))
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) (is-eq tx-sender (get manufacturer-id improvement))) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status improvement) STATUS_IN_PROGRESS) ERR_INVALID_STATUS)
    (map-set improvements
      { improvement-id: improvement-id }
      (merge improvement {
        status: STATUS_COMPLETED,
        actual-completion: (some block-height),
        actual-cost: (some actual-cost)
      })
    )
    ;; Calculate ROI
    (let ((cost-savings (if (> actual-cost (get estimated-cost improvement)) u0 (- (get estimated-cost improvement) actual-cost)))
          (score-improvement (if (> actual-score (get baseline-score metrics)) (- actual-score (get baseline-score metrics)) u0)))
      (map-set improvement-metrics
        { improvement-id: improvement-id }
        (merge metrics {
          actual-score: (some actual-score),
          roi-percentage: (some (if (> actual-cost u0) (/ (* cost-savings u100) actual-cost) u0))
        })
      )
    )
    (ok true)
  )
)

(define-public (reject-improvement (improvement-id uint))
  (let ((improvement (unwrap! (map-get? improvements { improvement-id: improvement-id }) ERR_IMPROVEMENT_NOT_FOUND)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status improvement) STATUS_PROPOSED) ERR_INVALID_STATUS)
    (map-set improvements
      { improvement-id: improvement-id }
      (merge improvement { status: STATUS_REJECTED })
    )
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-improvement (improvement-id uint))
  (map-get? improvements { improvement-id: improvement-id })
)

(define-read-only (get-improvement-metrics (improvement-id uint))
  (map-get? improvement-metrics { improvement-id: improvement-id })
)

(define-read-only (get-next-improvement-id)
  (var-get next-improvement-id)
)
