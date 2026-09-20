<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_role', function (Blueprint $table) {
            $table->bigIncrements('v_roleId');

            $table->string('v_roleName', 100)->unique();
            $table->string('v_roleDescription', 255)->nullable();

            $table->boolean('v_isActive')->default(true);

            $table->dateTime('v_createdAt')->useCurrent();
            $table->dateTime('v_updatedAt')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_role');
    }
};