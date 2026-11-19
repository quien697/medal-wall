## REMOVED Requirements

### Requirement: Stored Medal Photo
**Reason**: A face is stored at the photo's own pixels inside the framed square, as the
`photo-uploads` requirement Photos Kept At Their Own Resolution sets for every framed photo.

**Migration**: Faces already stored stay 840 × 840. Faces saved from this change on are the
framed square at the photo's own resolution. Nothing reads a face's pixel size: every view
draws it at its own display size.
