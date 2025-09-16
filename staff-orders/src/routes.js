import express from 'express';
import { db, withTransaction } from './db.js';

export const router = express.Router();

// List all staff orders with staff info
router.get('/staff-orders', (req, res) => {
	const rows = db
		.prepare(
			`SELECT so.id, so.order_title, so.order_description, so.status, so.created_at, so.updated_at,
			        s.id AS staff_id, s.name AS staff_name, s.email AS staff_email
			 FROM staff_orders so
			 JOIN staff s ON s.id = so.staff_id
			 ORDER BY so.created_at DESC`
		)
		.all();
	res.json(rows);
});

// Create a new staff order
router.post('/staff-orders', (req, res) => {
	const { staff_id, order_title, order_description, status } = req.body || {};
	if (!staff_id || !order_title) {
		return res.status(400).json({ error: 'staff_id and order_title are required' });
	}
	const insert = db.prepare(
		'INSERT INTO staff_orders (staff_id, order_title, order_description, status) VALUES (?, ?, ?, ?)'
	);
	const info = insert.run(
		Number(staff_id),
		String(order_title),
		order_description ? String(order_description) : null,
		status ? String(status) : 'pending'
	);
	const created = db
		.prepare(
			`SELECT so.id, so.order_title, so.order_description, so.status, so.created_at, so.updated_at,
			        s.id AS staff_id, s.name AS staff_name, s.email AS staff_email
			 FROM staff_orders so JOIN staff s ON s.id = so.staff_id WHERE so.id = ?`
		)
		.get(info.lastInsertRowid);
	res.status(201).json(created);
});

// Update existing staff order
router.put('/staff-orders/:id', (req, res) => {
	const { id } = req.params;
	const { staff_id, order_title, order_description, status } = req.body || {};
	const existing = db.prepare('SELECT * FROM staff_orders WHERE id = ?').get(id);
	if (!existing) return res.status(404).json({ error: 'Not found' });

	const nextStaffId = staff_id !== undefined ? Number(staff_id) : existing.staff_id;
	const nextTitle = order_title !== undefined ? String(order_title) : existing.order_title;
	const nextDesc = order_description !== undefined ? String(order_description) : existing.order_description;
	const nextStatus = status !== undefined ? String(status) : existing.status;

	const update = db.prepare(
		`UPDATE staff_orders
		 SET staff_id = ?, order_title = ?, order_description = ?, status = ?, updated_at = CURRENT_TIMESTAMP
		 WHERE id = ?`
	);
	update.run(nextStaffId, nextTitle, nextDesc, nextStatus, id);
	const updated = db
		.prepare(
			`SELECT so.id, so.order_title, so.order_description, so.status, so.created_at, so.updated_at,
			        s.id AS staff_id, s.name AS staff_name, s.email AS staff_email
			 FROM staff_orders so JOIN staff s ON s.id = so.staff_id WHERE so.id = ?`
		)
		.get(id);
	res.json(updated);
});

// List staff for UI dropdowns
router.get('/staff', (req, res) => {
	const rows = db.prepare('SELECT id, name, email FROM staff ORDER BY name ASC').all();
	res.json(rows);
});


