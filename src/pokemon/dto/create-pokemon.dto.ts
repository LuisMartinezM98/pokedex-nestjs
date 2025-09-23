import { IsInt, IsPositive, MinLength, IsString, Min } from 'class-validator';

export class CreatePokemonDto {
  // isInt, isPositive, min 1
  @IsInt()
  @IsPositive()
  @Min(1)
  no: number;
  // isString
  @IsString()
  @MinLength(1)
  name: string;
}
