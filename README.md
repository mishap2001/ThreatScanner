# ThreatScore

ThreatScore is a Bash-based threat intelligence and scoring tool designed to evaluate the maliciousness of IPs, Domains, URLs, and File Hashes using multiple intelligence sources.

It aggregates results from several platforms, calculates a unified risk score, and presents a clear verdict.

---

## Features

- Multi-source threat intelligence enrichment
- Supports multiple observable types:
  - IP Address
  - Domain
  - URL
  - File Hash (MD5 / SHA1 / SHA256)
- Automated scoring engine (0–100)
- Clear verdict classification:
  - Clean / Unknown
  - Low Risk
  - Suspicious
  - Highly Malicious
- Colored CLI output for readability
- API-based modular architecture
- Works even with partial API availability

---

## Data Sources

ThreatScore integrates with the following platforms (API keys required):

- VirusTotal
- AbuseIPDB
- IPinfo
- AlienVault OTX
- urlscan.io
- Cloudflare URL Scanner
- MalwareBazaar
- ThreatYeti (AlphaMountain)

---

## Installation

### Requirements

Make sure the following tools are installed:

```bash
sudo apt update
sudo apt install -y curl jq
```

### Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/ThreatScore.git
cd ThreatScore
chmod +x threatscore.sh
```

---

## Configuration

API keys are required for all supported services.

On first run, the script will prompt you to enter your API keys:

- VirusTotal
- MalwareBazaar
- OTX (AlienVault)
- Cloudflare
- urlscan.io
- ThreatYeti
- IPinfo
- AbuseIPDB

These will be saved securely in:

```
.ThreatScore.conf
```

---

## Usage

Run the script:

```bash
bash ThreatScore.sh
```

### Menu Options

```
1) Check IP
2) Check Domain
3) Check URL
4) Check Hash
5) Exit
```

---

## How It Works

1. Validates user input  
2. Queries relevant threat intelligence sources  
3. Extracts key indicators:
   - Malicious detections
   - Suspicious flags
   - Abuse scores
   - Threat pulses  
4. Normalizes results  
5. Calculates a final score  
6. Assigns a verdict  

---

## Scoring System

The score is calculated based on:

- VirusTotal detections
- Suspicious flags
- AbuseIPDB score
- OTX pulse count
- ThreatYeti risk level
- Multi-source correlation

### Score Mapping

| Score | Verdict |
|------|--------|
| 0–19 | Clean / Unknown |
| 20–44 | Low Risk |
| 45–74 | Suspicious |
| 75–100 | Highly Malicious |

---

## Example Output

```
=======================
     Threat Score
=======================
Type: IP
Score: 78 / 100
Verdict: HIGHLY MALICIOUS
```

---
