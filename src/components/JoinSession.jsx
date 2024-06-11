import { Button } from './Buttons';
import { NameInput } from './NameInput';

export function JoinSession({
  username,
  handleChange,
  handleJoin,
  loading,
  error,
}) {
  function handleSubmit(e) {
    e.preventDefault();
    handleJoin(username);
  }

  return (
    <div className='bg-surface w-96 px-6 py-8 rounded-xl overflow-hidden flex flex-col gap-2 text-uiText/50 shadow-xl dark:shadow-black/80 ring-1 ring-surfaceAlt2/10'>
      <h3 id='title' className='text-md font-bold text-uiText text-center mb-4'>
        Enter your name
      </h3>
      <span id='full_description' className='hidden'>
        <p>Enter a name to continue.</p>
      </span>
      <form onSubmit={handleSubmit}>
        <div className='flex justify-center gap-x-2 mb-5'>
          <NameInput
            placeholder=''
            inputValue={username}
            onChange={handleChange}
            error={error}
          />
        </div>
        <Button
          appearance='primary'
          style='roundedText'
          fullWidth={true}
          loading={loading}
          disabled={username?.length < 6}
          type='submit'
        >
          Join session
        </Button>
      </form>
    </div>
  );
}
