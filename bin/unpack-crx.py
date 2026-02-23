#!/usr/bin/env python3

import sys
import os
import struct
import zipfile
import json
from pathlib import Path

def unpack_crx3(crx_path, output_dir):
    """Unpack a CRX3 file to a directory"""
    with open(crx_path, 'rb') as f:
        # Read CRX3 header
        magic = f.read(4)
        if magic == b'Cr24':  # CRX3 format
            version = struct.unpack('<I', f.read(4))[0]
            header_size = struct.unpack('<I', f.read(4))[0]
            
            # Skip the header
            f.seek(12 + header_size)
            
            # The rest is a ZIP file
            zip_content = f.read()
            
            # Write ZIP content to temp file
            zip_path = crx_path + '.zip'
            with open(zip_path, 'wb') as zf:
                zf.write(zip_content)
            
            # Extract ZIP
            with zipfile.ZipFile(zip_path, 'r') as zf:
                zf.extractall(output_dir)
            
            # Clean up
            os.remove(zip_path)
            return True
            
        elif magic[:2] == b'PK':  # Already a ZIP file
            f.seek(0)
            with open(crx_path + '.zip', 'wb') as zf:
                zf.write(f.read())
            
            with zipfile.ZipFile(crx_path + '.zip', 'r') as zf:
                zf.extractall(output_dir)
            
            os.remove(crx_path + '.zip')
            return True
        else:
            # Try CRX2 format
            f.seek(0)
            magic = f.read(4)
            if magic != b'Cr24':
                # Might be CRX2
                f.seek(0)
                # Skip CRX2 header (variable size)
                # CRX2 has magic, version, public key length, signature length
                f.read(4)  # magic
                f.read(4)  # version
                pub_len = struct.unpack('<I', f.read(4))[0]
                sig_len = struct.unpack('<I', f.read(4))[0]
                f.read(pub_len)  # public key
                f.read(sig_len)  # signature
                
                # Rest is ZIP
                zip_content = f.read()
                zip_path = crx_path + '.zip'
                with open(zip_path, 'wb') as zf:
                    zf.write(zip_content)
                
                with zipfile.ZipFile(zip_path, 'r') as zf:
                    zf.extractall(output_dir)
                
                os.remove(zip_path)
                return True
    
    return False

def modify_manifest(manifest_path):
    """Remove update_url and other store-specific fields from manifest"""
    with open(manifest_path, 'r') as f:
        manifest = json.load(f)
    
    # Remove fields that tie it to Chrome Web Store
    fields_to_remove = ['update_url', 'key', 'differential_fingerprint']
    for field in fields_to_remove:
        manifest.pop(field, None)
    
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f, indent=2)

def main():
    if len(sys.argv) != 3:
        print("Usage: unpack-crx.py <crx_file> <output_dir>")
        sys.exit(1)
    
    crx_path = sys.argv[1]
    output_dir = sys.argv[2]
    
    if not os.path.exists(crx_path):
        print(f"Error: {crx_path} does not exist")
        sys.exit(1)
    
    # Create output directory
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    # Unpack CRX
    if unpack_crx3(crx_path, output_dir):
        print(f"✅ Unpacked {os.path.basename(crx_path)}")
        
        # Modify manifest if it exists
        manifest_path = os.path.join(output_dir, 'manifest.json')
        if os.path.exists(manifest_path):
            modify_manifest(manifest_path)
            print(f"✅ Modified manifest.json")
    else:
        print(f"❌ Failed to unpack {os.path.basename(crx_path)}")
        sys.exit(1)

if __name__ == "__main__":
    main()