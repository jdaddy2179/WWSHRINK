# AWS Load Balancer Architecture

**Development Environment Documentation**

---

## High-Level Architecture

```mermaid
flowchart TB
    Clients(["External / Internal Clients"])

    subgraph VPC["VPC: vpc-050b894b70344d265"]
        direction TB
        subgraph LBLayer["Load Balancer Layer (Multi-AZ)"]
            ALB["🔷 ALB<br/>alb-sle-oag-dev"]
            NLB1["🔶 NLB<br/>app-nlb-dev"]
            NLB2["🔶 NLB<br/>app-nlb-utility-dev"]
            NLB3["🔶 NLB<br/>app-nlb-ww2-dev"]
        end

        subgraph AZs["Availability Zones"]
            AZ1["us-east-1a<br/>subnet-0a23c67319acc01d3"]
            AZ2["us-east-1b<br/>subnet-07cb66859ecf52390"]
            AZ3["us-east-1d<br/>subnet-0290e7ce3aebe9fec"]
        end

        subgraph Backends["Backend Resources"]
            App["🖥️ App Servers"]
            Web["🌐 WW2 Web Servers"]
            Util["⚙️ Utility Servers"]
            OAG["🔐 Okta Access Gateway"]
            Lambda["λ Lambda Functions"]
        end
    end

    Clients --> ALB
    Clients --> NLB1
    Clients --> NLB2
    Clients --> NLB3

    LBLayer -.spans.-> AZs

    ALB --> OAG
    ALB --> Lambda
    NLB1 --> App
    NLB2 --> Util
    NLB3 --> Web

    classDef alb fill:#4A90E2,stroke:#2C5282,color:#fff
    classDef nlb fill:#ED8936,stroke:#9C4221,color:#fff
    classDef backend fill:#48BB78,stroke:#22543D,color:#fff
    classDef az fill:#F7FAFC,stroke:#4A5568,color:#1A202C
    class ALB alb
    class NLB1,NLB2,NLB3 nlb
    class App,Web,Util,OAG,Lambda backend
    class AZ1,AZ2,AZ3 az
```

---

## 1. Network Mapping Overview

| VPC ID |
|--------|
| `vpc-050b894b70344d265` |

### Availability Zone Subnet Mapping

```mermaid
flowchart LR
    VPC["VPC<br/>vpc-050b894b70344d265"]
    VPC --> AZ1["📍 us-east-1a<br/>use1-az1"]
    VPC --> AZ2["📍 us-east-1b<br/>use1-az2"]
    VPC --> AZ3["📍 us-east-1d<br/>use1-az6"]
    AZ1 --> S1["subnet-0a23c67319acc01d3"]
    AZ2 --> S2["subnet-07cb66859ecf52390"]
    AZ3 --> S3["subnet-0290e7ce3aebe9fec"]

    classDef vpc fill:#2C5282,stroke:#1A365D,color:#fff
    classDef az fill:#4A90E2,stroke:#2C5282,color:#fff
    classDef subnet fill:#BEE3F8,stroke:#2C5282,color:#1A365D
    class VPC vpc
    class AZ1,AZ2,AZ3 az
    class S1,S2,S3 subnet
```

| Availability Zone | Subnet ID | AZ ID |
|-------------------|-----------|-------|
| us-east-1a | `subnet-0a23c67319acc01d3` | use1-az1 |
| us-east-1b | `subnet-07cb66859ecf52390` | use1-az2 |
| us-east-1d | `subnet-0290e7ce3aebe9fec` | use1-az6 |

---

## 2. Application Load Balancer: `alb-sle-oag-dev`

| Property | Value |
|----------|-------|
| DNS Name | `internal-alb-sle-oag-dev-1298542252.us-east-1.elb.amazonaws.com` |
| Certificate | `sle-ds11-windward.dqdev.ad` |

### Listener Rule Flow

```mermaid
flowchart LR
    Client(["Client Request"])
    ALB{{"alb-sle-oag-dev"}}

    Client --> ALB

    ALB -->|"Port 80<br/>HTTP"| L80["Listener :80"]
    ALB -->|"Port 8080<br/>HTTP"| L8080["Listener :8080"]
    ALB -->|"Port 443<br/>HTTPS"| L443["Listener :443"]

    L80 -->|"Redirect"| L443
    L8080 -->|"Forward"| TGL["tg-alb-lambda-nextgen-dev"]
    L443 -->|"Forward"| TGO["TG-OAG"]

    TGL --> Lambda["λ Lambda Functions<br/>(Next-Gen Platform)"]
    TGO --> OAG["🔐 Okta Access Gateway"]

    classDef client fill:#E2E8F0,stroke:#2D3748,color:#1A202C
    classDef alb fill:#4A90E2,stroke:#2C5282,color:#fff
    classDef listener fill:#90CDF4,stroke:#2C5282,color:#1A365D
    classDef tg fill:#9F7AEA,stroke:#553C9A,color:#fff
    classDef backend fill:#48BB78,stroke:#22543D,color:#fff
    class Client client
    class ALB alb
    class L80,L8080,L443 listener
    class TGL,TGO tg
    class Lambda,OAG backend
```

### Listener Rules

| Port | Protocol | Action | Target Group |
|------|----------|--------|--------------|
| 80 | HTTP | Redirect | HTTPS:443 |
| 8080 | HTTP | Forward | `tg-alb-lambda-nextgen-dev` |
| 443 | HTTPS | Forward | `TG-OAG` |

---

## 3. Network Load Balancers

```mermaid
flowchart TB
    Client(["Client Traffic"])

    subgraph NLBs["Network Load Balancers"]
        N1["🔶 app-nlb-dev"]
        N2["🔶 app-nlb-utility-dev"]
        N3["🔶 app-nlb-ww2-dev"]
    end

    Client --> N1
    Client --> N2
    Client --> N3

    N1 -->|"TCP :80<br/>Stickiness ON"| TG1["app-nlb-tg-tcp-80"]
    N1 -->|"TCP :8101-8221<br/>Mixed Stickiness"| TG2["app-nlb-tg-tcp-[Port]"]
    N2 -->|"TCP :80<br/>Stickiness OFF"| TG3["app-utility-tg"]
    N3 -->|"TLS :443<br/>Stickiness OFF"| TG4["app-nlb-tg-ww2-tcp-80"]

    TG1 --> App1["🖥️ App Servers"]
    TG2 --> App2["🖥️ App Servers"]
    TG3 --> Util["⚙️ Utility Servers"]
    TG4 --> Web["🌐 WW2 Web Servers"]

    classDef client fill:#E2E8F0,stroke:#2D3748,color:#1A202C
    classDef nlb fill:#ED8936,stroke:#9C4221,color:#fff
    classDef tg fill:#9F7AEA,stroke:#553C9A,color:#fff
    classDef backend fill:#48BB78,stroke:#22543D,color:#fff
    class Client client
    class N1,N2,N3 nlb
    class TG1,TG2,TG3,TG4 tg
    class App1,App2,Util,Web backend
```

### `app-nlb-dev`

| Port | Protocol | Target Group | Stickiness |
|------|----------|--------------|------------|
| 80 | TCP | `app-nlb-tg-tcp-80` | On |
| 8101-8221 | TCP | `app-nlb-tg-tcp-[Port]` | Mixed |

### `app-nlb-utility-dev`

| Property | Value |
|----------|-------|
| DNS Name | `app-nlb-utility-dev-f1fb2db12773ee67...` |

| Port | Protocol | Target Group | Stickiness |
|------|----------|--------------|------------|
| 80 | TCP | `app-utility-tg` | Off |

### `app-nlb-ww2-dev`

| Property | Value |
|----------|-------|
| Certificate | `sle-ds11-config-windward.dqdev.ad` |

| Port | Protocol | Target Group | Stickiness |
|------|----------|--------------|------------|
| 443 | TLS | `app-nlb-tg-ww2-tcp-80` | Off |

---

## 4. Target Group Definitions

```mermaid
flowchart LR
    subgraph TGs["📦 Target Groups"]
        direction TB
        T1["app-nlb-tg-tcp-*"]
        T2["app-nlb-tg-ww2-tcp-*"]
        T3["app-nlb-tg-tls-443"]
        T4["app-utility-tg"]
        T5["TG-OAG"]
        T6["tg-alb-lambda-nextgen-dev"]
    end

    subgraph Backends["🎯 Backend Resources"]
        direction TB
        B1["🖥️ App Servers"]
        B2["🌐 Web Servers (WW2)"]
        B3["⚙️ Utility Servers"]
        B4["🔐 Okta Access Gateway"]
        B5["λ Lambda Functions"]
    end

    T1 --> B1
    T2 --> B2
    T3 --> B1
    T4 --> B3
    T5 --> B4
    T6 --> B5

    classDef tg fill:#9F7AEA,stroke:#553C9A,color:#fff
    classDef backend fill:#48BB78,stroke:#22543D,color:#fff
    class T1,T2,T3,T4,T5,T6 tg
    class B1,B2,B3,B4,B5 backend
```

Mapping of target groups to backend resource types.

| Target Group Pattern | Backend Type | Description |
|----------------------|--------------|-------------|
| `app-nlb-tg-tcp-*` | App Servers | Primary application instances for TCP traffic. |
| `app-nlb-tg-ww2-tcp-*` | Web Servers | Dedicated WW2 web instances. |
| `app-nlb-tg-tls-443` | App Servers | App instances for encrypted NLB traffic. |
| `app-utility-tg` | Utility Servers | Infrastructure support and utility services. |
| `TG-OAG` | Okta Access Gateway | Access management gateway servers. |
| `tg-alb-lambda-nextgen-dev` | Lambda Functions | Serverless functions for the next-gen platform. |

---

## Summary: Traffic Path Quick Reference

```mermaid
flowchart LR
    subgraph Ingress["🌐 Ingress Points"]
        I1["HTTPS :443"]
        I2["HTTP :80 / :8080"]
        I3["TCP :80"]
        I4["TCP :8101-8221"]
        I5["TLS :443"]
    end

    subgraph LBs["⚖️ Load Balancers"]
        ALB2["ALB<br/>alb-sle-oag-dev"]
        NLBa["NLB<br/>app-nlb-dev"]
        NLBu["NLB<br/>app-nlb-utility-dev"]
        NLBw["NLB<br/>app-nlb-ww2-dev"]
    end

    subgraph Dest["🎯 Destinations"]
        D1["Okta Access Gateway"]
        D2["Lambda (Next-Gen)"]
        D3["App Servers"]
        D4["Utility Servers"]
        D5["WW2 Web Servers"]
    end

    I1 --> ALB2 --> D1
    I2 --> ALB2 --> D2
    I3 --> NLBa --> D3
    I4 --> NLBa
    I3 --> NLBu --> D4
    I5 --> NLBw --> D5

    classDef ingress fill:#FED7D7,stroke:#9B2C2C,color:#1A202C
    classDef lb fill:#4A90E2,stroke:#2C5282,color:#fff
    classDef dest fill:#48BB78,stroke:#22543D,color:#fff
    class I1,I2,I3,I4,I5 ingress
    class ALB2,NLBa,NLBu,NLBw lb
    class D1,D2,D3,D4,D5 dest
```

---

*Document generated on May 7, 2026 | AWS Cloud Engineering*
