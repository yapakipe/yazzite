# Custom bazzite image: yazzite

This repository is for building a custom bazzite image for my own use. Feel free to use it, but it comes with zero guarantee! Also feel free to file bugs if you find an issue _specific to this image_, but again, there's no guarantee I'll even look at it :-) This is just me tinkering, not me providing a great image for people to use... Ok, ça, c'est fait.

This is based on the ublue-os image template found at [https://github.com/ublue-os/image-template](https://github.com/ublue-os/image-template). The original readme for that repo at the time _this_ repo was created is [ORIGINAL-TEMPLATE-README.md](./ORIGINAL-TEMPLATE-README.md)

# Purpose of this image

This image is meant to be bazzite plus:
- gparted
- blivet-gui
- coolercontrol
- liquidctl

That's it for now.

# Rebasing to this template from another Fedora atomic image (with KDE Plasma)

See [Bazzite's rebase guide](https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_and_Rebasing/rebase_guide/) for instructions and warnings about rebasing.

Pay special attention to the warning that says "Rebasing between different desktop environments (e.g. KDE Plasma to GNOME) may cause issues and is unsupported.".

This image is using KDE Plasma, so only rebase from/to other Fedora atomic images that also use KDE Plasma as their desktop environment.

To rebase to this image:

```bash
rpm-ostree rebase  ostree-image-signed:docker://ghcr.io/yapakipe/yazzite:latest
```

To rebase back to bazzite or bazzite-dx, first check whether you have any layered packages that were installed on to of your current image:
```
rpm-ostree status
```

If you have multiple images available, the current one will be marked with a bullet on the left. If you see a "LayeredPackages" line for your current image, then remove them with:

```
rpm-ostree reset
```

Then reboot. rpm-ostree status should now show no layered packages for the active image.

Once you're sure you're on a clean image, you can switch to various other images with the following commands:

- Bazzite: `sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite:stable`
    - Or is it `ostree-image-signed:docker://ghcr.io/ublue-os/bazzite:stable` ?  
- Bazzite DX: `sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-dx:stable`
- Aurora: `sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/aurora:stable`
- Aurora DX: Rebase to the regular Aurora (above), then run `ujust devmode` and choose Enable

Note: Not sure about the 'ostree-unverified-registry' vs. 'ostree-image-signed:docker', what's that about?

