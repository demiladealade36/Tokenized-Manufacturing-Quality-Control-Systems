# Tokenized Manufacturing Quality Control System

A comprehensive blockchain-based quality control system for manufacturing companies built on the Stacks blockchain using Clarity smart contracts.

## Overview

This system provides a complete solution for managing manufacturing quality control processes through tokenized smart contracts. It enables transparent, immutable tracking of manufacturers, quality standards, inspections, defects, and continuous improvements.

## System Architecture

The system consists of five interconnected smart contracts:

### 1. Manufacturer Verification Contract (`manufacturer-verification.clar`)
- **Purpose**: Manages registration and verification of manufacturing companies
- **Key Features**:
    - Manufacturer registration with certifications
    - Verification status management
    - Quality score tracking
    - Inspection statistics

### 2. Quality Standards Contract (`quality-standards.clar`)
- **Purpose**: Defines and manages quality standards and requirements
- **Key Features**:
    - Create and update quality standards
    - Version control for standards
    - Category-based organization
    - Minimum score requirements

### 3. Inspection Coordination Contract (`inspection-coordination.clar`)
- **Purpose**: Coordinates quality inspections and manages inspection lifecycle
- **Key Features**:
    - Inspector registration and management
    - Inspection scheduling
    - Status tracking (scheduled, in-progress, completed)
    - Score recording and notes

### 4. Defect Tracking Contract (`defect-tracking.clar`)
- **Purpose**: Tracks manufacturing defects and their resolution
- **Key Features**:
    - Defect reporting with severity levels
    - Assignment and status management
    - Category-based tracking
    - Resolution documentation

### 5. Improvement Management Contract (`improvement-management.clar`)
- **Purpose**: Manages quality improvements and tracks progress
- **Key Features**:
    - Improvement proposals with cost estimates
    - Approval workflow
    - Progress tracking
    - ROI calculation

## Contract Interactions

\`\`\`
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   Manufacturer  │────│  Quality         │────│   Inspection        │
│   Verification  │    │  Standards       │    │   Coordination      │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
│                       │                         │
│                       │                         │
└───────────────────────┼─────────────────────────┘
│
┌───────────────────────┼─────────────────────────┐
│                       │                         │
│                       │                         │
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│     Defect      │────│   Improvement    │    │      System         │
│    Tracking     │    │   Management     │    │    Integration      │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
\`\`\`

## Key Features

### 🏭 **Manufacturer Management**
- Secure registration and verification process
- Certification tracking
- Quality score monitoring
- Performance analytics

### 📋 **Quality Standards**
- Standardized quality requirements
- Version control and updates
- Category-based organization
- Compliance tracking

### 🔍 **Inspection Process**
- Automated scheduling
- Inspector assignment
- Real-time status updates
- Comprehensive reporting

### 🐛 **Defect Management**
- Severity-based classification
- Assignment and tracking
- Resolution documentation
- Trend analysis

### 📈 **Continuous Improvement**
- Improvement proposals
- Cost-benefit analysis
- Progress monitoring
- ROI calculation

## Status Constants

### Manufacturer Status
- \`STATUS_PENDING\` (0): Awaiting verification
- \`STATUS_VERIFIED\` (1): Verified and active
- \`STATUS_SUSPENDED\` (2): Temporarily suspended
- \`STATUS_REVOKED\` (3): Verification revoked

### Inspection Status
- \`STATUS_SCHEDULED\` (0): Inspection scheduled
- \`STATUS_IN_PROGRESS\` (1): Currently being conducted
- \`STATUS_COMPLETED\` (2): Successfully completed
- \`STATUS_CANCELLED\` (3): Cancelled

### Defect Severity
- \`SEVERITY_LOW\` (1): Minor issues
- \`SEVERITY_MEDIUM\` (2): Moderate impact
- \`SEVERITY_HIGH\` (3): Significant problems
- \`SEVERITY_CRITICAL\` (4): Critical failures

### Improvement Priority
- \`PRIORITY_LOW\` (1): Nice to have
- \`PRIORITY_MEDIUM\` (2): Should implement
- \`PRIORITY_HIGH\` (3): Important improvement
- \`PRIORITY_URGENT\` (4): Critical improvement

## Getting Started

### Prerequisites
- Stacks blockchain node
- Clarity CLI tools
- Node.js (for testing)

### Installation

1. Clone the repository:
   \`\`\`bash
   git clone <repository-url>
   cd manufacturing-quality-control
   \`\`\`

2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

3. Run tests:
   \`\`\`bash
   npm test
   \`\`\`

### Deployment

Deploy contracts to Stacks blockchain:

\`\`\`bash
# Deploy manufacturer verification contract
clarinet deploy contracts/manufacturer-verification.clar

# Deploy quality standards contract
clarinet deploy contracts/quality-standards.clar

# Deploy inspection coordination contract
clarinet deploy contracts/inspection-coordination.clar

# Deploy defect tracking contract
clarinet deploy contracts/defect-tracking.clar

# Deploy improvement management contract
clarinet deploy contracts/improvement-management.clar
\`\`\`

## Usage Examples

### Register a Manufacturer
\`\`\`clarity
(contract-call? .manufacturer-verification register-manufacturer
"Acme Manufacturing Co."
(list "ISO9001" "ISO14001" "OHSAS18001"))
\`\`\`

### Create a Quality Standard
\`\`\`clarity
(contract-call? .quality-standards create-standard
"ISO9001-2015"
"ISO 9001:2015 Quality Management Systems"
"Requirements for quality management systems"
(list "Document control" "Management review" "Internal audit")
u80
"quality-management")
\`\`\`

### Schedule an Inspection
\`\`\`clarity
(contract-call? .inspection-coordination schedule-inspection
'ST1MANUFACTURER123
'ST1INSPECTOR456
"ISO9001-2015"
u2000)
\`\`\`

### Report a Defect
\`\`\`clarity
(contract-call? .defect-tracking report-defect
'ST1MANUFACTURER123
(some u1)
"Surface finish defect"
"Rough surface finish detected on batch #123"
u2
"surface-quality")
\`\`\`

### Propose an Improvement
\`\`\`clarity
(contract-call? .improvement-management propose-improvement
'ST1MANUFACTURER123
"Upgrade measurement equipment"
"Install new precision measurement tools"
u3
u2000
u50000
"Improve measurement accuracy by 20%"
u70
u90)
\`\`\`

## Testing

The system includes comprehensive tests using Vitest:

\`\`\`bash
# Run all tests
npm test

# Run specific test file
npm test manufacturer-verification.test.js

# Run tests with coverage
npm run test:coverage
\`\`\`

## Security Considerations

- **Access Control**: Contract owner privileges for critical functions
- **Data Validation**: Input validation for all parameters
- **State Management**: Proper state transitions and validations
- **Error Handling**: Comprehensive error codes and messages

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions and support, please open an issue in the GitHub repository.

## Roadmap

- [ ] Integration with IoT sensors
- [ ] Advanced analytics dashboard
- [ ] Mobile application
- [ ] Multi-chain support
- [ ] AI-powered quality predictions
  \`\`\`
  \`\`\`

Finally, let's create the PR details file:
