import mongoose, { model, PaginateModel, Schema } from "mongoose"

const AllSequenceSchema = new mongoose.Schema({
  _id: String,
  seq: Number
});

export default model('all_sequence', AllSequenceSchema)
