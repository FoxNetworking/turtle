git fetch --all
git reset --hard origin/main
/usr/local/bin/npm install
npx prisma generate
/usr/local/bin/npm run build
/usr/local/bin/node /home/container/dist