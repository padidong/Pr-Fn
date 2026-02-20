const express = require('express');
const cors = require('cors');
const db = require('./db');

const app = express();

app.use(cors());
app.use(express.json());

// Health check (no DB needed)
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 1. Get all stations
app.get('/api/stations', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM polling_station ORDER BY station_id ASC');
        res.json(rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database error', details: err.message });
    }
});

// 2. Get all violation types
app.get('/api/violation_types', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM violation_type ORDER BY type_id ASC');
        res.json(rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database error', details: err.message });
    }
});

// 3. Get all reports with JOINs
app.get('/api/reports', async (req, res) => {
    try {
        const query = `
            SELECT 
                r.*, 
                s.station_name, 
                s.zone, 
                s.province, 
                v.type_name, 
                v.severity 
            FROM incident_report r
            JOIN polling_station s ON r.station_id = s.station_id
            JOIN violation_type v ON r.type_id = v.type_id
            ORDER BY r.timestamp DESC
        `;
        const [rows] = await db.query(query);
        res.json(rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database error', details: err.message });
    }
});

// 4. Create new report
app.post('/api/create_report', async (req, res) => {
    const { station_id, type_id, reporter_name, description, evidence_photo, timestamp, ai_result, ai_confidence } = req.body;

    if (!station_id || !type_id || !reporter_name || !description || !timestamp) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    try {
        const query = `
            INSERT INTO incident_report 
            (station_id, type_id, reporter_name, description, evidence_photo, timestamp, ai_result, ai_confidence) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        `;
        
        const [result] = await db.query(query, [
            station_id, 
            type_id, 
            reporter_name, 
            description, 
            evidence_photo || null, 
            timestamp, 
            ai_result || null, 
            ai_confidence || null
        ]);

        res.json({ success: true, report_id: result.insertId, message: 'Report created successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database error', details: err.message });
    }
});

// 5. Update AI results
app.post('/api/update_ai', async (req, res) => {
    const { report_id, ai_result, ai_confidence } = req.body;

    if (!report_id || !ai_result || ai_confidence === undefined) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    try {
        const query = `
            UPDATE incident_report 
            SET ai_result = ?, ai_confidence = ? 
            WHERE report_id = ?
        `;
        
        const [result] = await db.query(query, [ai_result, ai_confidence, report_id]);

        if (result.affectedRows > 0) {
            res.json({ success: true, message: 'AI result updated successfully' });
        } else {
            res.status(404).json({ error: 'Report not found or no changes made' });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database error', details: err.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, async () => {
    console.log(`Server running on http://localhost:${PORT}`);
    try {
        await db.query('SELECT 1');
        console.log('Database connected successfully');
    } catch (err) {
        console.error('Database connection failed:', err.message);
    }
});
