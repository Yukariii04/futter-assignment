const express = require('express');
const cors = require('cors')
const userModel = require('./model/user.model');
const noteModel = require('./model/note.model');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();

app.use(cors());
app.use(express.json());


// Middleware

function authCheck(req, res, next) {
    const header = req.headers['authorization'];

    if (!header) {
        return res.status(401).json({
            message: "No token"
        })
    }

    const token = header.split(' ')[1];

    if (!token) {
        return res.status(401).json({
            message: "No token"
        })
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.userId = decoded.id;
        next();
    }
    catch {
        return res.status(401).json({
            message: "Invalid token"
        })
    }
}

// Register

app.post('/register', async (req, res) => {
    const { name, email, phone, password } = req.body;

    if (!name || !email || !phone || !password) {
        return res.status(400).json({
            message: "All fields required"
        })
    }

    const existing = await userModel.findOne({ email });

    if (existing) {
        return res.status(400).json({
            message: "Email already registered"
        })
    }

    const hashed = await bcrypt.hash(password, 10);

    const user = await userModel.create({
        name: name,
        email: email,
        phone: phone,
        password: hashed
    })

    return res.status(201).json({
        message: "Registered successfully"
    })
})

// Login

app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    const user = await userModel.findOne({ email });

    if (!user) {
        return res.status(400).json({
            message: "User not found"
        })
    }

    const match = await bcrypt.compare(password, user.password);

    if (!match) {
        return res.status(400).json({
            message: "Wrong password"
        })
    }

    const token = jwt.sign(
        { id: user._id },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
    )

    return res.status(200).json({
        token: token,
        name: user.name,
        phone: user.phone
    })
})

// Get all notes

app.get('/notes', authCheck, async (req, res) => {
    const notes = await noteModel.find({
        userId: req.userId
    }).sort({ createdAt: -1 })

    return res.status(200).json({
        message: "all notes",
        notes: notes
    })
})

// Create note

app.post('/notes', authCheck, async (req, res) => {
    const { content } = req.body;

    if (!content) {
        return res.status(400).json({
            message: "Content required"
        })
    }

    const note = await noteModel.create({
        userId: req.userId,
        content: content
    })

    return res.status(201).json({
        message: "Note created",
        note: note
    })
})

// Update note

app.put('/notes/:id', authCheck, async (req, res) => {
    const { content } = req.body;

    const note = await noteModel.findOne({
        _id: req.params.id,
        userId: req.userId
    })

    if (!note) {
        return res.status(404).json({
            message: "Note not found"
        })
    }

    note.content = content;

    await note.save();

    return res.status(200).json({
        message: "Note updated",
        note: note
    })
})

// Delete note

app.delete('/notes/:id', authCheck, async (req, res) => {
    const note = await noteModel.findOne({
        _id: req.params.id,
        userId: req.userId
    })

    if (!note) {
        return res.status(404).json({
            message: "Note not found"
        })
    }

    await note.deleteOne();

    return res.status(200).json({
        message: "Note deleted"
    })
})

module.exports = app;