# To run this, install nix and enable experimental support for flakes (easiest
# done via
# https://github.com/DeterminateSystems/nix-installer#install-determinate-nix).
#
# Then run `nix develop` in the root of the repo to enter a development shell
# with the required dependencies installed.

{
  description = "Development shell for pkg-repo-configs with reprepro 5.3.1";

  inputs = {
    # A fork of nixpkgs with the reprepro package pinned to 5.3.1.
    #
    # reprepro >5.3.1 requires migrating the X.db to a new format via `reprepro
    # translatelegacyreferences`, and will refuse to carry out commands until
    # that is done. However, the same versions also suffer from a regression
    # (https://bugs-devel.debian.org/cgi-bin/bugreport.cgi?bug=1095493) upon
    # which they can't act on the new DB format without throwing the following
    # error:
    #
    # ```
    # Exporting indices...
    # packages.db/jammy|prerelease|source: BDB0088 DB_SECONDARY_BAD: Secondary index inconsistent with primary
    # Internal error of the underlying BerkeleyDB database:
    # Within packages.db subtable jammy|prerelease|source at c_get(DB_NEXT): BDB0088 DB_SECONDARY_BAD: Secondary index inconsistent with primary
    # ERROR: Could not finish exporting 'jammy'!
    # ```
    #
    # Amazing! Thus, we need to pin to 5.3.1 manually until this mess is sorted
    # out. Nixpkgs has only ever had 5.4.7 packaged, hence the fork.
    nixpkgs.url = "github:anoadragon453/nixpkgs/a519456e4d572179f353dc5feab13b4656c59b76";
  };

  outputs = { nixpkgs, ... }:
    let
      # The systems we anticipate will be running this flake.
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in {
          default = pkgs.mkShell {
            packages = [
              pkgs.reprepro
            ];
          };
        });
    };
}
