# lewiscallow.com

Personal portfolio site, deployed on AWS and provisioned with Terraform.

Live at [lewiscallow.com](https://lewiscallow.com)

---

## Architecture

```
Browser
  │
  ▼
Cloudflare DNS (lewiscallow.com → CloudFront)
  │
  ▼
CloudFront (HTTPS, caching, edge delivery)
  │  Origin Access Control
  ▼
S3 bucket (private — CloudFront only)
```

The S3 bucket is fully private. Only this specific CloudFront distribution can read from it, enforced via Origin Access Control (OAC) and a least-privilege bucket policy scoped by `AWS:SourceArn`. The public never touches S3 directly.

---

## Stack

| Layer | Choice | Why |
|---|---|---|
| Storage | S3 | Static hosting, versioned, encrypted at rest |
| CDN / HTTPS | CloudFront + ACM | Global edge delivery, free TLS on custom domain |
| DNS | Cloudflare | Domain registered at Cloudflare; registrar locks nameservers so delegation to Route 53 wasn't possible |
| IaC | Terraform | Industry standard, reproducible, everything in code |
| State | S3 + DynamoDB | Remote state with locking — works across machines |

---

## Trade-offs and decisions

**Why is the bucket private with OAC instead of public?**
Making the bucket public is the quick path — S3 static website hosting works out of the box. But it means the bucket is directly accessible, bypassing CloudFront entirely. OAC keeps the bucket locked down: all traffic goes through CloudFront, the bucket is never exposed, and the bucket policy ensures only this specific distribution can read it.

**Why Cloudflare DNS instead of Route 53?**
The domain is registered at Cloudflare, and Cloudflare Registrar doesn't allow external nameservers. Transferring the domain just to use Route 53 wasn't worth it for a static site. Cloudflare DNS with a CNAME pointing at CloudFront works cleanly — Cloudflare's CNAME flattening handles the apex domain without needing Route 53 alias records.

**Why PriceClass_100 for CloudFront?**
Uses only North America and Europe edge locations. For a UK portfolio site, there's no meaningful benefit to paying for Asia/South America edges. Cheaper, still fast for the intended audience.

**What I'd do differently**
Register the domain somewhere that allows custom nameservers (Route 53 registrar, Namecheap, Porkbun) so the full architecture — including DNS — can live in Terraform. Also: add a GitHub Actions pipeline to automate `aws s3 sync` and cache invalidation on every push to `main`, rather than running those commands manually.

---

## How to deploy

### Prerequisites
- AWS account with credentials configured (`aws configure`)
- Terraform >= 1.5
- S3 bucket and DynamoDB table for remote state (bootstrap manually — see below)

### Bootstrap state storage (one-time)
Create these manually in the AWS console before first deploy:
- S3 bucket: `lewis-tfstate-c565nl` (versioning enabled, public access blocked)
- DynamoDB table: `lewis-tfstate-lock` (partition key: `LockID`, on-demand billing)

### Deploy

```bash
terraform init
terraform plan
terraform apply
```

### Update site content

```bash
aws s3 sync site/ s3://lewis-portfolio-site-7sn4l
aws cloudfront create-invalidation --distribution-id <id> --paths "/*"
```

### DNS (manual step)
Add a CNAME record in Cloudflare:
- Name: `@`
- Target: the CloudFront distribution domain (from `terraform output cloudfront_domain_name`)
- Proxy status: DNS only (grey cloud)

---

## Project context

P01 of a series of AWS projects I'm building while working toward a cloud engineering career. Built as a first-line IT support apprentice at a small MSP, learning AWS and Terraform independently.
