import Database from 'better-sqlite3';
import fs from 'fs';
import path from 'path';

const dataDir = path.join(process.cwd(), 'data');
const dbPath = path.join(dataDir, 'app.db');

if (!fs.existsSync(dataDir)) {
	fs.mkdirSync(dataDir, { recursive: true });
}

export const db = new Database(dbPath);

export function initializeSchema() {
	const schemaSql = `
	CREATE TABLE IF NOT EXISTS staff (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL,
		email TEXT UNIQUE
	);

	CREATE TABLE IF NOT EXISTS staff_orders (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		staff_id INTEGER NOT NULL,
		order_title TEXT NOT NULL,
		order_description TEXT,
		status TEXT NOT NULL DEFAULT 'pending',
		created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
		updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE
	);

	CREATE INDEX IF NOT EXISTS idx_staff_orders_staff_id ON staff_orders(staff_id);
	`;

	db.exec(schemaSql);
}

export function seedIfEmpty() {
	const staffCount = db.prepare('SELECT COUNT(*) AS c FROM staff').get().c;
	if (staffCount === 0) {
		const insertStaff = db.prepare('INSERT INTO staff (name, email) VALUES (?, ?)');
		insertStaff.run('Alice Johnson', 'alice@example.com');
		insertStaff.run('Bob Smith', 'bob@example.com');
	}

	const orderCount = db.prepare('SELECT COUNT(*) AS c FROM staff_orders').get().c;
	if (orderCount === 0) {
		const staff = db.prepare('SELECT id FROM staff').all();
		if (staff.length > 0) {
			const insertOrder = db.prepare(
				'INSERT INTO staff_orders (staff_id, order_title, order_description, status) VALUES (?, ?, ?, ?)'
			);
			for (const s of staff) {
				insertOrder.run(s.id, 'Initial Order', 'Demo order for seeding', 'pending');
			}
		}
	}
}

export function withTransaction(work) {
	const transaction = db.transaction(work);
	return transaction();
}


