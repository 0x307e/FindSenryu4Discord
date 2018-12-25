db.createUser({
  user: "senryu",
  pwd: "senryu",
  roles:
    [
      {
        role: "userAdmin",
        db: "senryu"
      }
    ]
})
