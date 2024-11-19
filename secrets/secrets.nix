let
  jackPc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO4HOkIIuHnAhukRppCJ4lWpR/XfT77cO4b9fFVz2cu";
  jackMobile = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICukXQCZucPptRM5ciQCEY5/6qvMedGymAtI5yOVCl3F";
  users = [jackPc jackMobile];
  systems = [];
in {
  "tailscaleAuth.age".publicKeys = users ++ systems;
}
