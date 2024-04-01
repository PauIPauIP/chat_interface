use crate::label::{LabelState, LabeledAudio};
use crate::{PredictIterator, Sample};

/// Labels an iterator of speech samples as either speech or non-speech according
/// to the provided speech sensitity.
pub struct LabelIterator<T, I, const N: usize>
where
    I: Iterator,
{
    pub(super) iter: PredictIterator<T, I, N>,
    pub(super) state: LabelState<T, N>,
}

impl<T, I, const N: usize> Iterator for LabelIterator<T, I, N>
where
    T: Sample,
    I: Iterator<Item = T>,
{
    type Item = LabeledAudio<T, N>;

    fn next(&mut self) -> Option<Self::Item> {
        if let Some(buffered) = self.state.try_buffer() {
            return Some(buffered);
        }

        for (chunk, probability) in self.iter.by_ref() {
            if let Some(audio) = self.state.try_next(chunk, probability) {
                return Some(audio);
            }
        }

        self.state.flush()
    }
}
