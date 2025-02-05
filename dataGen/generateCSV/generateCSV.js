const fs = require('fs');
const { faker } = require('@faker-js/faker');

const generateCSV = () => {
  const entries = [];
  entries.push('PayeeID,Name,Email'); // Header

  for (let i = 1; i <= 500; i++) {
    const payeeID = `import${i}`;
    const name = faker.person.firstName();
    const email = `${faker.internet.username()}@varicentmock.com`;
    entries.push(`${payeeID},${name},${email}`);
  }

  fs.writeFileSync('payees.csv', entries.join('\n'), 'utf8');
};

generateCSV();