{
  users = {
    mutableUsers = false;
    users.root.hashedPassword = "!";
  };
  services.getty.autologinUser = "root";
}
