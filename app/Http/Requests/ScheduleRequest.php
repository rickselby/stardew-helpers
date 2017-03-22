<?php

namespace App\Http\Requests;

use App\Services\Seasons;
use App\Services\Villagers;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ScheduleRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize()
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array
     */
    public function rules(Villagers $villagers, Seasons $seasons)
    {
        return [
            'villager' => [
                'required',
                Rule::in($villagers->getList()->toArray())
            ],
            'season' => [
                'required',
                Rule::in($seasons->getList()->toArray())
            ],
            'day' => 'required|integer|between:1,28',
        ];
    }
}
